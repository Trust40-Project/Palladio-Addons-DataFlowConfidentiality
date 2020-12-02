package org.palladiosimulator.dataflow.confidentiality.pcm.queryutils

import java.util.Stack
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.indirections.repository.DataChannel
import org.palladiosimulator.indirections.repository.DataSinkRole
import org.palladiosimulator.pcm.core.composition.AssemblyContext

@Data
class DataSinkRoleWithContext implements OutgoingDataDestination {
	val DataChannel dataChannel
	val DataSinkRole dataSinkRole
	val Stack<AssemblyContext> context
}
