package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import org.eclipse.core.runtime.IProgressMonitor
import org.osgi.service.component.annotations.Component
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis
import org.palladiosimulator.dataflow.confidentiality.pcm.resources.DefaultModelConstants
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

/**
 * The analysis collects all data types that are received and sent at the actor processes
 * representing the entry level system calls. The data types are specified by the characteristic
 * type {@link DefaultModelConstants#CT_ACTUAL_DATATYPE_ID}. Written data types are determined by
 * looking at the received data types at stores that have influences from the actor processes
 * representing the entry level system call. Influences are detected by checking if the actor
 * processes are in the traversed nodes characteristic type
 * {@link org.palladiosimulator.dataflow.confidentiality.defaultmodels.DefaultModelConstants#CT_TRAVERSED_NODES_ID}.
 */
@Component
class ActualDataTypesAtELSCsAnalysis extends CharacteristicBasedAnalysisBase implements DataTypeUsageAnalysis {

	new() {
		super("Actual Data Types at ELSCs Analysis", "f922c07e-1d90-4543-955a-27e4b94f78cd")
	}

	override getUsedDataTypes(Iterable<EntryLevelSystemCall> elscs,
		IProgressMonitor monitor) throws InterruptedException {
		val analysisRun = new ActualDataTypesAtELSCsAnalysisRun(elscs)
		analysisRun.run(monitor)
	}

}
