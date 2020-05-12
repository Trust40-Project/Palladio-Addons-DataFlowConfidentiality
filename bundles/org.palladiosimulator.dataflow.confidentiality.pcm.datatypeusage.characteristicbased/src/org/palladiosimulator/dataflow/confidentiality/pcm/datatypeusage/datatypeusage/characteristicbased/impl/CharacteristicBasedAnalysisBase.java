package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;

import org.eclipse.core.runtime.IProgressMonitor;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public abstract class CharacteristicBasedAnalysisBase implements DataTypeUsageAnalysis {

    private final String name;
    private final String uuid;

    public CharacteristicBasedAnalysisBase(String name, String uuid) {
        this.name = name;
        this.uuid = uuid;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public String getUUID() {
        return uuid;
    }

    @Override
    public Collection<DataTypeUsageAnalysisResult> getUsedDataTypes(EntryLevelSystemCall elsc, IProgressMonitor monitor)
            throws InterruptedException {
        var result = getUsedDataTypes(Arrays.asList(elsc), monitor);
        if (result.size() == 1) {
            return result.values()
                .iterator()
                .next();
        }
        return Collections.emptyList();
    }

}
