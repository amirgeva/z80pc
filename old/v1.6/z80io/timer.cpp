#define F_CPU 8000000UL
#include <avr/io.h>
#include <avr/interrupt.h>


volatile uint16_t timer_counter=0;
uint16_t last_timer_counter=0;

ISR(TIMER2_OVF_vect)
{
	++timer_counter;
}

void setup_timer()
{
	TCCR2 = (1<<CS22) | (1<<CS20);
	TIMSK = (1<<TOIE2);
}

void stop_timer()
{
	TCCR2 = 0;
}

void send_timer_update(uint16_t counter);

void loop_timer()
{
	if (timer_counter!=last_timer_counter)
	{
		last_timer_counter=timer_counter;
		send_timer_update(timer_counter);
	}
}