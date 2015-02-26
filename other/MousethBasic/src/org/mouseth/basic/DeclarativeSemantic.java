package org.mouseth.basic;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import bsh.EvalError;
import bsh.Interpreter;
import fri.patterns.interpreter.parsergenerator.Semantic;
import fri.patterns.interpreter.parsergenerator.syntax.Rule;

public class DeclarativeSemantic implements Semantic {
	private Util util;
	private Interpreter interpreter; 
	private Properties ruleProperties;
	
	public DeclarativeSemantic(InputStream propertiesInput, InputStream bshInput) {
		this.ruleProperties = new Properties();
		try {
			this.ruleProperties.load(propertiesInput);
		} catch (IOException e) {
			throw new RuntimeException("Error while reading rule properties: " + e.getMessage(), e);
		}
		
		this.interpreter = new Interpreter();
		try {
			this.interpreter.eval(new InputStreamReader(bshInput));
		} catch (EvalError e) {
			throw new RuntimeException("Error while reading default script: " + e.getMessage(), e);
		}

		util = new Util();		
	}
	
	public Object doSemantic(Rule rule, List parseResults, List resultRanges) {
		String rl = ruleProperties.getProperty(rule.getNonterminal());
		Object ret = rl;
		if (rl != null) {
			if (rl.startsWith("#")) {
				try {
					this.interpreter.set("params", parseResults.toArray());
					this.interpreter.set("util", util);
					ret = this.interpreter.eval(rl.substring(1));
				} catch (EvalError e) {
					throw new RuntimeException(e);
				}
			} else {
				ret = MessageFormat.format(rl, parseResults.toArray());
			}
			return ret;
		}
		if (parseResults.size() == 1) {
			return this.convertList(parseResults).get(0);
		}
		return parseResults;
	}
	
	public void reset() {
		
	}

	@SuppressWarnings("unchecked")
	protected List<Object> convertList(List<?> list) {
		return new ArrayList<Object>(list);
	}
}
