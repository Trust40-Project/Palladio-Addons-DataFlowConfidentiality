package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl;

import de.uka.ipd.sdq.identifier.Identifier;

public interface TraceRecorder {
    
	default void addToTrace(Identifier srcElement, Identifier dstElement) {
		addToTrace(srcElement.getId(), dstElement.getId());
	}
	
	void addToTrace(String srcId, String dstId);
	
}
