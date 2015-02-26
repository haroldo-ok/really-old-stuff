package org.mouseth.basic;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import fri.patterns.interpreter.parsergenerator.Parser;
import fri.patterns.interpreter.parsergenerator.builder.SerializedParser;
import fri.util.TimeStopper;

public class DeclarativeCompiler {
	private Parser parser;
	private DeclarativeSemantic semantic;
	
	public DeclarativeCompiler(String name, InputStream syntaxInput, InputStream propertiesInput, InputStream bshInput, boolean verbose) throws Exception {		
		TimeStopper timer = new TimeStopper();

		this.parser = new SerializedParser(false).get(null, syntaxInput, name);
		System.err.println("time to build parser was "+timer.getInterval());

		this.semantic = new DeclarativeSemantic(propertiesInput, bshInput);
	}
	
	public String parse(Reader input) throws IOException {
		this.parser.setInput(input);
		this.semantic.reset();
		boolean ok = this.parser.parse(this.semantic);
		if (!ok) {
			return null;
		}
		return this.parser.getResult().toString();
	}
}
