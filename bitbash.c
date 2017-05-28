#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
 
#define PAGE_SIZE (4*1024)
#define BLOCK_SIZE (4*1024)
 
volatile unsigned *gpio;

// GPIO setup macros. Always use INP_GPIO(x) before using OUT_GPIO(x) or SET_GPIO_ALT(x,y)
#define INP_GPIO(g) *(gpio+((g)/10)) &= ~(7<<(((g)%10)*3))
#define OUT_GPIO(g) *(gpio+((g)/10)) |=  (1<<(((g)%10)*3))
#define SET_GPIO_ALT(g,a) *(gpio+(((g)/10))) |= (((a)<=3?(a)+4:(a)==4?3:2)<<(((g)%10)*3))
 
#define GPIO_SET *(gpio+7)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR *(gpio+10) // clears bits which are 1 ignores bits which are 0
 
#define GET_GPIO(g) (*(gpio+13)&(1<<g)) // 0 if LOW, (1<<g) if HIGH
 
#define GPIO_PULL *(gpio+37) // Pull up/pull down
#define GPIO_PULLCLK0 *(gpio+38) // Pull up/pull down clock

#define DATA_GPIO_LSB 8
#define DATA_WIDTH 8
#define CLK_GPIO 6
#define FULL_EMPTY_GPIO 25

void setup_io()
{
   int  mem_fd;
   void *gpio_map;

   if ((mem_fd = open("/dev/gpiomem", O_RDWR|O_SYNC) ) < 0) {
      printf("can't open /dev/gpiomem \n");
      exit(-1);
   }

   gpio_map = mmap(
      NULL,             //Any adddress in our space will do
      BLOCK_SIZE,       //Map length
      PROT_READ|PROT_WRITE,// Enable reading & writting to mapped memory
      MAP_SHARED,       //Shared with other processes
      mem_fd,           //File to map
      0					// gpiomem doesn't care what address we ask for
   );
 
   close(mem_fd); //No need to keep mem_fd open after mmap
 
   if (gpio_map == MAP_FAILED) {
      printf("mmap error %d\n", (int)gpio_map);//errno also set!
      exit(-1);
   }
 
   // Always use volatile pointer!
   gpio = (volatile unsigned *)gpio_map;
}

void tx_put(uint8_t data)
{
	GPIO_SET |= (uint32_t)data << DATA_GPIO_LSB;
	GPIO_CLR |= (uint32_t)(~data) << DATA_GPIO_LSB;
	while (GET_GPIO(FULL_EMPTY_GPIO))
		;
   GPIO_SET |= 1 << CLK_GPIO;
   GPIO_CLR |= 1 << CLK_GPIO;
}

uint8_t rx_get()
{
   uint8_t data;
   while (GET_GPIO(FULL_EMPTY_GPIO))
      ;
   data = (*(gpio + 13) >> DATA_GPIO_LSB) & 0xff;
   GPIO_SET |= 1 << CLK_GPIO;
   GPIO_CLR |= 1 << CLK_GPIO;
   return data;
}

int main(int argc, char **argv)
{
	int i;
   int doing_rx = argc > 1 && !strcmp(argv[1], "-r");
   printf("Setting up for %s\n", doing_rx ? "RX" : "TX");

	setup_io();
	for (i = DATA_GPIO_LSB; i < DATA_GPIO_LSB + DATA_WIDTH; ++i)
	{
		INP_GPIO(i);
		OUT_GPIO(i);
	}
	INP_GPIO(CLK_GPIO);
	OUT_GPIO(CLK_GPIO);
	INP_GPIO(FULL_EMPTY_GPIO);

   if (doing_rx)
   {
      while (1)
         putchar(rx_get());
   }
   else
   {
   	while (1)
   		tx_put(getchar());
   }
   return 0;
}
