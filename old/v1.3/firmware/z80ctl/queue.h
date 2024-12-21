#ifndef H_QUEUE
#define H_QUEUE

#include <avr/io.h>

#ifdef __cplusplus
extern "C" {
#endif

#define INDEX_BITS 6
#define QUEUE_SIZE (1 << INDEX_BITS)
#define QUEUE_MASK (QUEUE_SIZE-1)

	typedef struct Queue_
	{
		volatile uint8_t array[QUEUE_SIZE];
		volatile uint8_t write_head : INDEX_BITS;
		volatile uint8_t read_head : INDEX_BITS;
	} Queue;

	int queue_init(Queue* q);
	int queue_empty(Queue* q);
	int queue_full(Queue* q);
	int queue_push(Queue* q, uint8_t b);
	uint8_t queue_pop(Queue* q);

#ifdef __cplusplus
};
#endif


#endif /* H_QUEUE */
