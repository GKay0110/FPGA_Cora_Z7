#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xuartps_hw.h"

extern char inbyte(void);

/* Adresse de l'IP AXI_Peripheral_0 (Address Editor de Vivado) */
#ifdef XPAR_AXI_PERIPHERAL_0_S00_AXI_BASEADDR
#define IP_BASE  XPAR_AXI_PERIPHERAL_0_S00_AXI_BASEADDR
#else
#define IP_BASE  0x44A00000
#endif

/* Registres de l'IP : adresse = IP_BASE + decalage */
#define REG_R_MAX       0x00   /* lecture : meilleur score de l'image */
#define REG_POS_X       0x04   /* lecture : colonne du meilleur point */
#define REG_POS_Y       0x08   /* lecture : ligne du meilleur point */
#define REG_THRESHOLD   0x0C   /* ecriture : seuil de detection (-2048 a 2047) */
#define REG_MODE        0x10   /* ecriture : 0 = image brute, 1 = overlay */
#define REG_FRAME_CNT   0x14   /* lecture : nombre d'images terminees */
#define REG_DMA_ADDR    0x18   /* ecriture : adresse de l'image du DMA */
#define REG_DMA_WIDTH   0x1C   /* ecriture : largeur */
#define REG_DMA_HEIGHT  0x20   /* ecriture : hauteur */
#define REG_DMA_START   0x24   /* ecriture : demarrage du DMA */

#define THRESHOLD_STEP         5
#define STATUS_EVERY_N_FRAMES  60   /* 60 images par seconde : 60 = 1 affichage par seconde */

XGpio MuxGpio;
static int paused = 0;   /* 1 = affichage automatique en pause */

static unsigned int reg_read(unsigned int offset)
{
    return Xil_In32(IP_BASE + offset);
}

static void reg_write(unsigned int offset, unsigned int value)
{
    Xil_Out32(IP_BASE + offset, value);
}

static void print_menu(void)
{
    xil_printf("\r\nTouches (une seule touche, sans Entree) :\r\n");
    xil_printf("  0 / 1 : source  TPG (mire de test) / DMA (image)\r\n");
    xil_printf("  a / b : affichage  image brute / detections en cyan\r\n");
    xil_printf("  + / - : seuil de detection +5 / -5\r\n");
    xil_printf("  p     : pause / reprise de l'affichage automatique\r\n");
    xil_printf("  h     : afficher ce menu\r\n\r\n");
}

int main()
{
    int threshold = 30;
    unsigned int frame, last_frame = 0, count = 0;
    char key;
    int score;

    init_platform();

    xil_printf("\r\n--- Controleur de la chaine video ---\r\n");
    xil_printf("Adresse de l'IP : 0x%08x\r\n", (unsigned int)IP_BASE);

    /* Multiplexeur de source : axi_gpio_2, canal 1 en sortie */
    if (XGpio_Initialize(&MuxGpio, XPAR_AXI_GPIO_2_DEVICE_ID) != XST_SUCCESS) {
        xil_printf("Erreur d'initialisation du GPIO !\r\n");
        cleanup_platform();
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&MuxGpio, 1, 0x0);
    XGpio_DiscreteWrite(&MuxGpio, 1, 0);

    /* Reglages de depart */
    reg_write(REG_MODE, 1);
    reg_write(REG_THRESHOLD, threshold);
    reg_write(REG_DMA_ADDR, 0x10000000);
    reg_write(REG_DMA_WIDTH, 640);
    reg_write(REG_DMA_HEIGHT, 480);
    reg_write(REG_DMA_START, 1);

    xil_printf("Source : mire de test (TPG), affichage B, seuil %d\r\n", threshold);
    print_menu();

    while (1) {
        /* Touche tapee dans le terminal ? */
        if (XUartPs_IsReceiveData(STDIN_BASEADDRESS)) {
            key = inbyte();
            switch (key) {
            case '0':
                XGpio_DiscreteWrite(&MuxGpio, 1, 0);
                xil_printf("-> Source : mire de test (TPG)\r\n");
                break;
            case '1':
                XGpio_DiscreteWrite(&MuxGpio, 1, 1);
                xil_printf("-> Source : image du DMA\r\n");
                break;
            case 'a':
                reg_write(REG_MODE, 0);
                xil_printf("-> Affichage A : image brute\r\n");
                break;
            case 'b':
                reg_write(REG_MODE, 1);
                xil_printf("-> Affichage B : detections en cyan sur l'image\r\n");
                break;
            case 'p':
                paused = !paused;
                xil_printf("-> Affichage %s\r\n", paused ? "en pause (p pour reprendre)" : "repris");
                break;
            case 'h':
                print_menu();
                break;
            case '+':
            case '-':
                threshold += (key == '+') ? THRESHOLD_STEP : -THRESHOLD_STEP;
                reg_write(REG_THRESHOLD, threshold);
                xil_printf("-> Seuil : %d\r\n", threshold);
                break;
            }
        }

        /* Une nouvelle image est terminee : on affiche le resultat de temps en temps */
        frame = reg_read(REG_FRAME_CNT);
        if (frame != last_frame) {
            last_frame = frame;
            if (!paused && ++count >= STATUS_EVERY_N_FRAMES) {
                count = 0;
                score = (int)reg_read(REG_R_MAX);
                xil_printf("Image %u | meilleur point : score %d en colonne %u, ligne %u | seuil %d%s\r\n",
                           frame, score, reg_read(REG_POS_X), reg_read(REG_POS_Y), threshold,
                           score < threshold ? " -> sous le seuil, pas de cyan" : "");
            }
        }
    }

    cleanup_platform();
    return 0;
}
