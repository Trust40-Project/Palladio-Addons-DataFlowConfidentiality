package org.palladiosimulator.dataflow.confidentiality.pcm.workflow;

import java.util.Optional;

public interface TransformPCMDFDToPrologWorkflow extends Runnable {
    
    Optional<String> getPrologProgram();
    
    Optional<TransitiveTransformationTrace> getTrace();
    
}
