package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.DataFlowGraph
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstance
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstanceRelation

@Data
class DataFlowGraphImpl implements DataFlowGraph {
	val Collection<EntityInstance> nodes
	val Collection<EntityInstanceRelation> edges
}
