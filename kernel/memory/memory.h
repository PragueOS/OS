#pragma once
#include<stdint.h>

void outb(uint16_t port, uint8_t data);
uint8_t inb(uint16_t port);