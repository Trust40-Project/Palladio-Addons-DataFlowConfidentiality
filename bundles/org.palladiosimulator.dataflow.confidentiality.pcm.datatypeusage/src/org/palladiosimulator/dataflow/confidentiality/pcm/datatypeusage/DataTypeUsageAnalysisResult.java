package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import java.util.Collection;
import java.util.Collections;

import org.palladiosimulator.pcm.repository.DataType;

import de.uka.ipd.sdq.identifier.Identifier;

public interface DataTypeUsageAnalysisResult {

    public interface EntityInstance {
        Identifier getEntity();

        Collection<Identifier> getContext();
    }

    public interface EntityInstanceRelation {
        EntityInstance getFrom();

        EntityInstance getTo();
    }

    public interface DataFlowGraph {
        Collection<EntityInstance> getNodes();

        Collection<EntityInstanceRelation> getEdges();
    }

    public interface EmptyDataFlowGraph extends DataFlowGraph {
        
        public static final DataFlowGraph INSTANCE = new EmptyDataFlowGraph() {
        };
        
        default Collection<EntityInstance> getNodes() {
            return Collections.emptyList();
        }

        default Collection<EntityInstanceRelation> getEdges() {
            return Collections.emptyList();
        }
    }

    Collection<DataType> getReadDataTypes();

    Collection<DataType> getWriteDataTypes();

    DataFlowGraph getDataFlowGraph();

}
