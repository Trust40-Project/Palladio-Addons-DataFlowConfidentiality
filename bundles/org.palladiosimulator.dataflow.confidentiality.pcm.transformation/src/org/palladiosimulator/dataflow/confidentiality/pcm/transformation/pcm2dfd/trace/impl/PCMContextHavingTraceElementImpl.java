package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import java.util.Collection;
import java.util.Collections;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMContextHavingTraceElement;

import de.uka.ipd.sdq.identifier.Identifier;

public class PCMContextHavingTraceElementImpl<T extends EObject> extends PCMTraceElementImpl<T>
        implements PCMContextHavingTraceElement {

    private final Collection<? extends Identifier> context;

    public PCMContextHavingTraceElementImpl(T element, Collection<? extends Identifier> context) {
        super(element);
        this.context = context;
    }

    @Override
    public Collection<Identifier> getContext() {
        return Collections.unmodifiableCollection(context);
    }

}
