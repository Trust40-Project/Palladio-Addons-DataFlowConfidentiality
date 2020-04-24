package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import java.util.Collection;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.TraceEntry;

import de.uka.ipd.sdq.identifier.Identifier;

public interface TransformationTraceModifier {

    default void addTraceEntry(EObject pcmElement, Identifier dfdelement) {
        var dfdEntry = new DFDTraceElementImpl(dfdelement);
        var pcmEntry = new PCMTraceElementImpl<EObject>(pcmElement);
        addTraceEntry(new TraceEntryImpl(dfdEntry, pcmEntry));
    }

    default void addTraceEntry(EObject pcmElement, Collection<? extends Identifier> pcmElementContext, Identifier dfdelement) {
        var dfdEntry = new DFDTraceElementImpl(dfdelement);
        var pcmEntry = new PCMContextHavingTraceElementImpl<EObject>(pcmElement, pcmElementContext);
        addTraceEntry(new TraceEntryImpl(dfdEntry, pcmEntry));
    }

    void addTraceEntry(TraceEntry entry);

}