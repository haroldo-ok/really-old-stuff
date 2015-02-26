SOURCE_FILES := $(wildcard *.java)


.SUFFIXES: .java .class

.java.class:
	javac $<


.PHONY: all clean rebuild run subdirs

all: $(patsubst %.java, %.class, $(SOURCE_FILES))

clean:
	rm -f *.class

rebuild: clean all

run: all

subdirs: ;