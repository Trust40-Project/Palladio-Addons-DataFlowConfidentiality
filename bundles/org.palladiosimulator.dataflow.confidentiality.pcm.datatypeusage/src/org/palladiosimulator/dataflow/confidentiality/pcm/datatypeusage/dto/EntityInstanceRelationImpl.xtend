package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto

import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstance
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstanceRelation

@Data
class EntityInstanceRelationImpl implements EntityInstanceRelation {
	val EntityInstance from
	val EntityInstance to
}
