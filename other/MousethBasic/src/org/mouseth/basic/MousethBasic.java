package org.mouseth.basic;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;

public class MousethBasic {
	
	public static void main(String[] args) throws Exception {
		if (args.length <= 0) {
			System.err.println("SYNTAX: java " + MousethBasic.class.getName()
					+ " file.bas output.mth.txt");
			System.err.println("	Mouseth BASIC Compiler");
		} else {
			// read the syntax
			InputStream syntaxInput = MousethBasic.class.getResourceAsStream("ClassicBasic.syntax");
			InputStream propertiesInput = MousethBasic.class.getResourceAsStream("ClassicBasic.properties");
			InputStream bshInput = MousethBasic.class.getResourceAsStream("ClassicBasic.bsh");

			DeclarativeCompiler compiler = new DeclarativeCompiler("ClassicBasic", syntaxInput, propertiesInput, bshInput, true);

			String fileToParse = null;
			String fileToWrite = null;
			for (int i = 0; i < args.length; i++) {
				if (args[i].startsWith("-")) {
					
				} else {
					if (fileToParse == null) {
						fileToParse = args[i];
					} else if (fileToWrite == null) {
						fileToWrite = args[i];
					}
				}
			}

			System.err
					.println("========================================================");
			System.err.println("Parsing: " + fileToParse);

			FileReader parseInput = new FileReader(fileToParse);
			String result = compiler.parse(parseInput);
			
			FileWriter parseOutput = new FileWriter(fileToWrite);
			parseOutput.write(result);
			parseOutput.close();

			System.err
					.println("========================================================");
/*				System.err.println("Parsing took "
					+ timer.getInterval() + " millis");*/

/*			for (int i = 0; i < args.length; i++) {
				String fileToParse = args[i];
				FileReader parseInput = new FileReader(fileToParse);
				System.err
						.println("========================================================");
				System.err.println("Parsing: " + fileToParse);

				String result = compiler.parse(parseInput);

				System.err.println(result);
				System.err
						.println("========================================================");*/
/*				System.err.println("Parsing took "
						+ timer.getInterval() + " millis");*/
//			}
		}
	}

}
