AS = as
LK = lk

all: WindrvXM.sys

WindrvXM.sys: WindrvXM.o
	$(LK) -o $@ $<

WindrvXM.o: WindrvXM.S
	$(AS) -o $@ $<

clean:
	rm -f WindrvXM.sys WindrvXM.o

.PHONY: all clean
