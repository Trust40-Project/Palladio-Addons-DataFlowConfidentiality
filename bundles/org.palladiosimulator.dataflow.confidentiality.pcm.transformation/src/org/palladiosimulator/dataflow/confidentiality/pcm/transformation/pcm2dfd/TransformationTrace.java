package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd;

public interface TransformationTrace {

	Iterable<String> getDestinationIds(String srcId);
	
	Iterable<String> getSourceIds(String dstId);
	
}
