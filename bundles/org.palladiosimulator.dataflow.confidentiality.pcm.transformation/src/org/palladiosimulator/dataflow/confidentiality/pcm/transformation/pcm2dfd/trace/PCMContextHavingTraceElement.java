package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace;

import java.util.Stack;

import de.uka.ipd.sdq.identifier.Identifier;

public interface PCMContextHavingTraceElement extends PCMSingleTraceElement {

    Stack<Identifier> getContext();
    
}
