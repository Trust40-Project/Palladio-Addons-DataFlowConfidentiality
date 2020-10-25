package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided;

import java.util.Stack;

import org.palladiosimulator.pcm.core.composition.AssemblyContext;

public final class TransformationConstants {

    public static Stack<AssemblyContext> EMPTY_STACK = new Stack<>();
    public static String RESULT_PIN_NAME = "RETURN";
    
    private TransformationConstants() {
        // intentionally left blank
    }
    
}
