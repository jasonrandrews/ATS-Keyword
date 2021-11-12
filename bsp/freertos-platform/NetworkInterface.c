/*
 * Copyright (c) 2021 Arm Limited. All rights reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the License); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "stdio.h"
#include <stdint.h>

#include "FreeRTOS.h"
#include "task.h"
#include "FreeRTOS_IP.h"
#include "FreeRTOS_Sockets.h"
#include "NetworkBufferManagement.h"
#include "NetworkInterface.h"
#include "FreeRTOS_IP_Private.h"
#include "semphr.h"

#include "cmsis.h"
#include "cmsis_driver_config.h"
#include "lan91c111.h"

#define ETH_DEV             SMSC9220_ETH_DEV
#define CRC_LENGTH_BYTES    4U

static TaskHandle_t xReceiveTask = NULL;
static SemaphoreHandle_t xRXSemaphore;
static SemaphoreHandle_t xTXSemaphore;

static void smsc9220_Receive_task( void *pvParameters );

/**
 * So called interrupt from lan91 ethernet
*/
void my_lan91_callback(lan91_event_t event, void *userData)
{
    BaseType_t taskWoken = pdFALSE;

    //NVIC_ClearPendingIRQ(ETHERNET_IRQn);
    NVIC_DisableIRQ(ETHERNET_IRQn);

    vTaskNotifyGiveFromISR(xReceiveTask, &taskWoken);
    portYIELD_FROM_ISR(taskWoken);
}

BaseType_t xNetworkInterfaceInitialise( void )
{
    //enum smsc9220_error_t ret = SMSC9220_ERROR_NONE;
    uint8_t MACaddr[ipMAC_ADDRESS_LENGTH_BYTES] = {0};

    FreeRTOS_debug_printf(("\r\nInit SMSC 9220 Ethernet driver...\r\n"));

    /* Execution must not be taken away during Ethernet controller init */
    taskENTER_CRITICAL();
    vTaskSuspendAll();
    //ret = smsc9220_init(&ETH_DEV, &busy_wait_ms);
    LAN91_init();
    xTaskResumeAll();
    taskEXIT_CRITICAL();

    /* Register ethernet interrupt handler */
    LAN91_SetCallback(my_lan91_callback, NULL);
//    if (ret != SMSC9220_ERROR_NONE) {
//        printf("\r\nError in SMSC 9220 Ethernet init.\r\n");
//        return pdFALSE;
//    } else {
//        printf(" done!\r\n");
//    }

    //smsc9220_read_mac_address(&ETH_DEV, MACaddr);
    read_MACaddr(MACaddr);
    printf("%x %x %x %x %x %x", MACaddr[0], MACaddr[1], MACaddr[2], MACaddr[3], MACaddr[4], MACaddr[5]);
    FreeRTOS_UpdateMACAddress((const uint8_t *)MACaddr);

    xRXSemaphore = xSemaphoreCreateMutex();
    xTXSemaphore = xSemaphoreCreateMutex();

    // create receive task
    xTaskCreate(smsc9220_Receive_task, "smsc9220 receive", 1024, NULL, configMAX_PRIORITIES-2, NULL);

    //smsc9220_enable_interrupt(&ETH_DEV, SMSC9220_INTERRUPT_RX_STATUS_FIFO_LEVEL);
    //NVIC_EnableIRQ(ETHERNET_IRQn);

    return pdTRUE;
}

BaseType_t xNetworkInterfaceOutput( NetworkBufferDescriptor_t * const pxDescriptor,
                                    BaseType_t xReleaseAfterSend )
{
    bool ret;
    xSemaphoreTake(xTXSemaphore, portMAX_DELAY);
    //smsc9220_send_by_chunks(&ETH_DEV, (uint32_t)pxDescriptor->xDataLength, true,
    //                        (char*)pxDescriptor->pucEthernetBuffer,
    //                        (uint32_t)pxDescriptor->xDataLength);
    //printf("Sending frame\r\n");
    vTaskDelay(10);
    //pxDescriptor->xDataLength /= 4;
    ret = LAN91_send_frame( (uint32_t *)pxDescriptor->pucEthernetBuffer, (uint32_t *) &(pxDescriptor->xDataLength));

    if(!ret) {
        FreeRTOS_debug_printf(("Error in sending frame!!!\r\n"));
    }

    xSemaphoreGive(xTXSemaphore);

    /* Call the standard trace macro to log the send event. */
    iptraceNETWORK_INTERFACE_TRANSMIT();

    if (xReleaseAfterSend == pdTRUE) {
        vReleaseNetworkBufferAndDescriptor( pxDescriptor );
    }

    return pdTRUE;
}

// FIXME would be nicer to use something like this in device cfg:
// #define SMSC9220_Ethernet_Interrupt_Handler     ETHERNET_IRQHandler
// and than here SMSC9220_Ethernet_Interrupt_Handler(void)

/*void ETHERNET_Handler(void)
{
    BaseType_t taskWoken = pdFALSE;
    if (smsc9220_get_interrupt(&ETH_DEV, SMSC9220_INTERRUPT_RX_STATUS_FIFO_LEVEL)) {

        smsc9220_disable_interrupt(&ETH_DEV, SMSC9220_INTERRUPT_RX_STATUS_FIFO_LEVEL);
        smsc9220_clear_interrupt(&ETH_DEV, SMSC9220_INTERRUPT_RX_STATUS_FIFO_LEVEL);
        NVIC_ClearPendingIRQ(ETHERNET_IRQn);
        //NVIC_DisableIRQ(ETHERNET_IRQn); // does this needed??

        vTaskNotifyGiveFromISR(xReceiveTask, &taskWoken);
        // if (taskWoken != pdTRUE) {
        //     printf("Error waking RX task from ISR");
        // }
    } else {
        // not expected interrupt
    }
    portYIELD_FROM_ISR(taskWoken);
}*/

//static uint8_t static_buffer_for_test[1000];

static void smsc9220_Receive_task( void *pvParameters )
{
    FreeRTOS_debug_printf(("smsc9220 ethernet receive task created\r\n"));
    NetworkBufferDescriptor_t *pxBufferDescriptor;
    /* Used to indicate that xSendEventStructToIPTask() is being called because
    of an Ethernet receive event. */
    IPStackEvent_t xRxEvent;

    xReceiveTask = xTaskGetCurrentTaskHandle();

    //smsc9220_enable_interrupt(&ETH_DEV, SMSC9220_INTERRUPT_RX_STATUS_FIFO_LEVEL);
    //NVIC_EnableIRQ(ETHERNET_IRQn);

    FreeRTOS_debug_printf(("Receive thred started!!!\r\n"));

    while (1) {
        /* Sleep thread until notified from Ethernet ISR */
        NVIC_EnableIRQ(ETHERNET_IRQn);
        //NVIC_ClearPendingIRQ(ETHERNET_IRQn);
        LAN91_SetInterruptMasks(MSK_RCV);
        //smsc9220_enable_interrupt(&ETH_DEV, SMSC9220_INTERRUPT_RX_STATUS_FIFO_LEVEL);
        ulTaskNotifyTake(pdFALSE, portMAX_DELAY);

        /* Peak transfer size */
        //message_length = smsc9220_peek_next_packet_size(&ETH_DEV);
        //    if (message_length == 0) {
        //        /* There are no packets to read */
        //        continue;
        //} else {
        //    /* The Ethernet controller cannot remove CRC from the end of the
        //     * incoming packet, thus it should be taken into account when
        //     * calculating the actual message length.*/
        //    message_length -= CRC_LENGTH_BYTES;
        //}

        /* Allocate a network buffer descriptor that points to a buffer
        large enough to hold the received frame.  As this is the simple
        rather than efficient example the received data will just be copied
        into this buffer. */
        pxBufferDescriptor = pxGetNetworkBufferWithDescriptor( LAN91_ETH_MTU_SIZE, 0 );

        if( pxBufferDescriptor != NULL )
        {
            xSemaphoreTake(xRXSemaphore, portMAX_DELAY);
            //received_bytes = smsc9220_receive_by_chunks(&ETH_DEV, pxBufferDescriptor->pucEthernetBuffer, message_length);
            //pxBufferDescriptor->xDataLength = received_bytes;

            if (!LAN91_receive_frame((uint32_t*)pxBufferDescriptor->pucEthernetBuffer, &pxBufferDescriptor->xDataLength)) {
                FreeRTOS_debug_printf(("Receive error!\r\n"));
            }

            /* See if the data contained in the received Ethernet frame needs
            to be processed.  NOTE! It is preferable to do this in
            the interrupt service routine itself, which would remove the need
            to unblock this task for packets that don't need processing. */
            if( eConsiderFrameForProcessing( pxBufferDescriptor->pucEthernetBuffer )
                                                                    == eProcessBuffer )
            {
                /* The event about to be sent to the TCP/IP is an Rx event. */
                xRxEvent.eEventType = eNetworkRxEvent;

                /* pvData is used to point to the network buffer descriptor that
                now references the received data. */
                xRxEvent.pvData = ( void * ) pxBufferDescriptor;

                /* Send the data to the TCP/IP stack. */
                if( xSendEventStructToIPTask( &xRxEvent, 0 ) == pdFALSE )
                {
                    /* The buffer could not be sent to the IP task so the buffer
                    must be released. */
                    vReleaseNetworkBufferAndDescriptor( pxBufferDescriptor );

                    /* Make a call to the standard trace macro to log the
                    occurrence. */
                    iptraceETHERNET_RX_EVENT_LOST();
                }
                else
                {
                    /* The message was successfully sent to the TCP/IP stack.
                    Call the standard trace macro to log the occurrence. */
                    iptraceNETWORK_INTERFACE_RECEIVE();
                }
            }
            else
            {
                /* The Ethernet frame can be dropped, but the Ethernet buffer
                must be released. */
                vReleaseNetworkBufferAndDescriptor( pxBufferDescriptor );
            }
            xSemaphoreGive(xRXSemaphore);
        }
        else
        {
            /* The event was lost because a network buffer was not available.
            Call the standard trace macro to log the occurrence. */
            iptraceETHERNET_RX_EVENT_LOST();
        }

    }
}
