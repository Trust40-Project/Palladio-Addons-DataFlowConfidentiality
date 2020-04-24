package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.impl;

import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.DFDTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.TraceEntry;

public class TraceEntryImpl implements TraceEntry {

    private final DFDTraceElement dfdEntry;
    private final PCMTraceElement pcmEntry;

    public TraceEntryImpl(DFDTraceElement dfdEntry, PCMTraceElement pcmEntry) {
        super();
        this.dfdEntry = dfdEntry;
        this.pcmEntry = pcmEntry;
    }

    @Override
    public DFDTraceElement getDFDEntry() {
        return dfdEntry;
    }

    @Override
    public PCMTraceElement getPCMEntry() {
        return pcmEntry;
    }

}
