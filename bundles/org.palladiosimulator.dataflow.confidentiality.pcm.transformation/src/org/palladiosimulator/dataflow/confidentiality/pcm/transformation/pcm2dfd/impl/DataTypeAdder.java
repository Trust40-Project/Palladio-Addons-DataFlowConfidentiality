package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import org.palladiosimulator.dataflow.dictionary.DataDictionary.DataType;

@FunctionalInterface
public interface DataTypeAdder {

	default void addToDictionary(DataType dataType) {
		if (dataType != null) {
			addToDictionaryWithoutNullCheck(dataType);
		}
	}
	
	void addToDictionaryWithoutNullCheck(DataType dataType);
	
}
