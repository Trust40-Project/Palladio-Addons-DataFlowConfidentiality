package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.DFDTraceElement;

import de.uka.ipd.sdq.identifier.Identifier;

public class DFDTraceElementImpl implements DFDTraceElement {

    private final Identifier element;

    public DFDTraceElementImpl(Identifier element) {
        this.element = element;
    }
    
    @Override
    public Identifier getElement() {
        return element;
    }

}
