package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import java.util.Stack;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.TraceEntry;

import de.uka.ipd.sdq.identifier.Identifier;

public interface TransformationTraceModifier {

    default void addTraceEntry(EObject from, Stack<? extends Identifier> fromContext, EObject to,
            Stack<? extends Identifier> toContext, Identifier dfdElement) {
        var pcmFromEntry = new PCMContextHavingTraceElementImpl<>(from, fromContext);
        var pcmToEntry = new PCMContextHavingTraceElementImpl<>(to, toContext);
        var pcmEntry = new PCMRelatedTraceElementImpl(pcmFromEntry, pcmToEntry);
        var dfdEntry = new DFDTraceElementImpl(dfdElement);
        addTraceEntry(new TraceEntryImpl(dfdEntry, pcmEntry));
    }

    default void addTraceEntry(EObject pcmElement, Identifier dfdelement) {
        var dfdEntry = new DFDTraceElementImpl(dfdelement);
        var pcmEntry = new PCMTraceElementImpl<EObject>(pcmElement);
        addTraceEntry(new TraceEntryImpl(dfdEntry, pcmEntry));
    }

    default void addTraceEntry(EObject pcmElement, Stack<? extends Identifier> pcmElementContext,
            Identifier dfdelement) {
        var dfdEntry = new DFDTraceElementImpl(dfdelement);
        var pcmEntry = new PCMContextHavingTraceElementImpl<EObject>(pcmElement, pcmElementContext);
        addTraceEntry(new TraceEntryImpl(dfdEntry, pcmEntry));
    }

    void addTraceEntry(TraceEntry entry);

}