package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.TransformationTrace;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;
import org.palladiosimulator.dataflow.dictionary.DataDictionary.DataDictionary;

public class TransformationResultImpl implements TransformationResult {
	private final DataFlowDiagram diagram;
	private final DataDictionary dictionary;
	private final TransformationTrace trace;

	public TransformationResultImpl(DataFlowDiagram diagram, DataDictionary dictionary, TransformationTrace trace) {
		super();
		this.diagram = diagram;
		this.dictionary = dictionary;
		this.trace = trace;
	}

	@Override
	public DataFlowDiagram getDiagram() {
		return diagram;
	}

	@Override
	public TransformationTrace getTrace() {
		return trace;
	}

	@Override
	public DataDictionary getDictionary() {
		return dictionary;
	}

}