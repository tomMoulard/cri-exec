CC = gcc
CFLAGS = -DTESTING -Wall -pedantic -Wextra -std=c99 -Werror -g -fmax-errors=5

DEPS = vswitch.c
BINS = vswitch
TDEP = test/vswitch_test.c
TBIN = vswitch_test

all: $(BINS)

$(BINS):
	$(CC) $(CFLAGS) $(DEPS) -o $(BINS)

test:
	$(CC) $(CFLAGS) -lcriterion $(TDEP) -o $(TBIN)

check:
	make a && make ARGS=" --verbose -j1 --full-stats" t

t:
	make test && ./$(TBIN) $(ARGS)

a:
	make clean && make

clean:
	rm -f $(BINS) $(TBIN)

.PHONY: clean test check t a
