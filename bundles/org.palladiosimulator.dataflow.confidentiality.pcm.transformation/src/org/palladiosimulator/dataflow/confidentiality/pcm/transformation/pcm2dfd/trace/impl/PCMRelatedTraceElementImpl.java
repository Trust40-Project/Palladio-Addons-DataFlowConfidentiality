package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMContextHavingTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMRelatedTraceElement;

public class PCMRelatedTraceElementImpl implements PCMRelatedTraceElement {

    private final PCMContextHavingTraceElement from;
    private final PCMContextHavingTraceElement to;

    public PCMRelatedTraceElementImpl(PCMContextHavingTraceElement from, PCMContextHavingTraceElement to) {
        super();
        this.from = from;
        this.to = to;
    }

    @Override
    public PCMContextHavingTraceElement getFromElement() {
        return from;
    }

    @Override
    public PCMContextHavingTraceElement getToElement() {
        return to;
    }

}
