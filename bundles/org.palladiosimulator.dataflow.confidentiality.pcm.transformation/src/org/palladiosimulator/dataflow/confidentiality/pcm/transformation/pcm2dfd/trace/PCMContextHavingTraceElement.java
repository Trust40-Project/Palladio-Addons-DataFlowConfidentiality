package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace;

import java.util.Collection;

import de.uka.ipd.sdq.identifier.Identifier;

public interface PCMContextHavingTraceElement extends PCMTraceElement {

    Collection<Identifier> getContext();
    
}
