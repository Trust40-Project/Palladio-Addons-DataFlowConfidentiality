package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Stack;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.DFDTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCM2DFDTransformationTrace;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMContextHavingTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMSingleTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.TraceEntry;

import de.uka.ipd.sdq.identifier.Identifier;

public class PCM2DFDTransformationTraceImpl implements PCM2DFDTransformationTrace, TransformationTraceModifier {

    private final Collection<TraceEntry> traceEntries = new ArrayList<>();

    public PCM2DFDTransformationTraceImpl() {
        // intentionally left blank
    }

    @Override
    public void addTraceEntry(TraceEntry entry) {
        traceEntries.add(entry);
    }

    @Override
    public Collection<DFDTraceElement> getDFDEntries(EObject pcmElement) {
        return traceEntries.stream()
            .filter(entry -> entry.getPCMEntry() instanceof PCMSingleTraceElement)
            .filter(entry -> ((PCMSingleTraceElement) entry.getPCMEntry()).getElement()
                .equals(pcmElement))
            .map(TraceEntry::getDFDEntry)
            .collect(Collectors.toList());
    }

    @Override
    public Collection<DFDTraceElement> getDFDEntries(EObject pcmElement, Stack<Identifier> pcmElementContext) {
        return traceEntries.stream()
            .filter(entry -> entry.getPCMEntry() instanceof PCMContextHavingTraceElement)
            .filter(entry -> ((PCMContextHavingTraceElement) entry.getPCMEntry()).getContext()
                .equals(pcmElementContext))
            .map(TraceEntry::getDFDEntry)
            .collect(Collectors.toList());
    }

    @Override
    public Collection<PCMTraceElement> getPCMEntries(Identifier dfdElement) {
        return traceEntries.stream()
            .filter(entry -> entry.getDFDEntry()
                .getElement()
                .equals(dfdElement))
            .map(TraceEntry::getPCMEntry)
            .collect(Collectors.toList());
    }

    @Override
    public Collection<DFDTraceElement> getDFDEntries(Predicate<PCMTraceElement> predicate) {
        return traceEntries.stream()
            .filter(e -> predicate.test(e.getPCMEntry()))
            .map(TraceEntry::getDFDEntry)
            .collect(Collectors.toList());
    }

}
