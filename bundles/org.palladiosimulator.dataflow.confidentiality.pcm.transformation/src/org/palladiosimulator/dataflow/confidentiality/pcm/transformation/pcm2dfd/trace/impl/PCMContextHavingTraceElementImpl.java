package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import java.util.Stack;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMContextHavingTraceElement;

import de.uka.ipd.sdq.identifier.Identifier;

public class PCMContextHavingTraceElementImpl<T extends EObject> extends PCMTraceElementImpl<T>
        implements PCMContextHavingTraceElement {

    private final Stack<? extends Identifier> context;

    public PCMContextHavingTraceElementImpl(T element, Stack<? extends Identifier> context) {
        super(element);
        this.context = context;
    }

    @Override
    public Stack<Identifier> getContext() {
        var copy = new Stack<Identifier>();
        copy.addAll(context);
        return copy;
    }

}
