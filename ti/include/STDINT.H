#ifndef STDINT_H
#define STDINT_H

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

typedef signed char int8_t;
typedef signed short int16_t;
typedef signed int int32_t;

typedef long int intmax_t;
typedef unsigned long int uintptr_t;

#define 	MMIO8(addr)   (*(volatile uint8_t *)(addr))
#define 	MMIO16(addr)   (*(volatile uint16_t *)(addr))
#define 	MMIO32(addr)   (*(volatile uint32_t *)(addr))

#endif