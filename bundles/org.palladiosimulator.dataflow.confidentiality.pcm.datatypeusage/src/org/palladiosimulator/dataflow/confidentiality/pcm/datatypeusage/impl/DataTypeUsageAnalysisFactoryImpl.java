package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.impl;

import java.util.Collection;
import java.util.Collections;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisFactory;

@Component
public class DataTypeUsageAnalysisFactoryImpl implements DataTypeUsageAnalysisFactory {

    private final Collection<DataTypeUsageAnalysis> analyses = new CopyOnWriteArrayList<>();

    public DataTypeUsageAnalysisFactoryImpl() {
        // intentionally left blank
    }

    @Reference(cardinality = ReferenceCardinality.MULTIPLE, policy = ReferencePolicy.DYNAMIC)
    public void addAnalysis(DataTypeUsageAnalysis analysis) {
        analyses.add(analysis);
    }
    
    public void removeAnalysis(DataTypeUsageAnalysis analysis) {
        analyses.remove(analysis);
    }

    @Override
    public Collection<DataTypeUsageAnalysis> getAnalyses() {
        return Collections.unmodifiableCollection(analyses);
    }

    @Override
    public Optional<DataTypeUsageAnalysis> getAnalysisByUUID(String uuid) {
        return analyses.stream().filter(a -> a.getUUID().equals(uuid)).findAny();
    }

}
