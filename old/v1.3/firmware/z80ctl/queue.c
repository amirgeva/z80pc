#include <stdint.h>
#include "queue.h"

int queue_init(Queue* q)
{
	q->read_head = 0;
	q->write_head = 0;
	return 1;
}

int queue_empty(Queue* q)
{
	return q->read_head == q->write_head;
}

int queue_full(Queue* q)
{
	return ((q->write_head+1)&QUEUE_MASK) == q->read_head;
}

int queue_push(Queue* q, uint8_t b)
{
	if (queue_full(q)) return 0;
	q->array[q->write_head++] = b;
	return 1;
}

uint8_t queue_pop(Queue* q)
{
	if (queue_empty(q)) return 0;
	return q->array[q->read_head++];
}
