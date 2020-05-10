package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace;

public interface PCMRelatedTraceElement extends PCMTraceElement {

    PCMContextHavingTraceElement getFromElement();

    PCMContextHavingTraceElement getToElement();

}
