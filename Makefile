.PHONY: compile test clean deps

REBAR=$(PWD)/rebar

all: compile

compile: deps
	$(REBAR) compile

deps:
	test -d deps || $(REBAR) get-deps

test: compile
	$(REBAR) eunit   
    
clean:
	$(REBAR) clean
