package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto

import de.uka.ipd.sdq.identifier.Identifier
import java.util.Collection
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstance

@Data
class EntityInstanceImpl implements EntityInstance {
	val Identifier entity;
	val Collection<Identifier> context;
}