package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.impl.DataTypeUsageQueryImpl;

public class DataTypeUsageQueryFactory {

    private DataTypeUsageQueryFactory() {
        // intentionally left blank
    }
    
    public static DataTypeUsageQuery create() {
        return new DataTypeUsageQueryImpl();
    }
    
}
