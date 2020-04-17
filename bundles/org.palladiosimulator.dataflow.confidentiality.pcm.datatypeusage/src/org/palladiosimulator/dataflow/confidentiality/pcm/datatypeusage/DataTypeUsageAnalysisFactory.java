package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import java.util.Collection;
import java.util.Optional;

public interface DataTypeUsageAnalysisFactory {

    Collection<DataTypeUsageAnalysis> getAnalyses();
    
    Optional<DataTypeUsageAnalysis> getAnalysisByUUID(String uuid);
    
}
