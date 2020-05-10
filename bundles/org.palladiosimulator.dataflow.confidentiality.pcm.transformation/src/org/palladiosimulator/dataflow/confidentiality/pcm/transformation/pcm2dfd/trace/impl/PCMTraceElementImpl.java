package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMSingleTraceElement;

public class PCMTraceElementImpl<T extends EObject> implements PCMSingleTraceElement {

    private final T element;
    
    public PCMTraceElementImpl(T element) {
        this.element = element;
    }
    
    @Override
    public EObject getElement() {
        return element;
    }

}
