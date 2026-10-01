/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */


#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"

extern char inbyte(void);

XGpio MuxGpio;

int main()
{
    init_platform();

    xil_printf("--- Controleur Video MUX ---\r\n");

    // Initialisation du troisieme AXI GPIO (axi_gpio_2)
    int status = XGpio_Initialize(&MuxGpio, XPAR_AXI_GPIO_2_DEVICE_ID);
    if (status != XST_SUCCESS) {
        xil_printf("Erreur d'initialisation du GPIO !\r\n");
        cleanup_platform();
        return XST_FAILURE;
    }

    // Configuration du canal 1 en sortie (0x0)
    XGpio_SetDataDirection(&MuxGpio, 1, 0x0);

    // Valeur par defaut : 0 (TPG / Mire de test)
    XGpio_DiscreteWrite(&MuxGpio, 1, 0);
    xil_printf("Source active : TPG (0)\r\n");
    xil_printf("Tapez '0' (TPG) ou '1' (DMA) dans le terminal :\r\n");

    // Boucle d'ecoute UART
    while(1) {
        char c = inbyte();
        if (c == '0') {
            XGpio_DiscreteWrite(&MuxGpio, 1, 0);
            xil_printf("-> Source : TPG\r\n");
        } else if (c == '1') {
            XGpio_DiscreteWrite(&MuxGpio, 1, 1);
            xil_printf("-> Source : DMA\r\n");
        }
    }

    cleanup_platform();
    return 0;
}
