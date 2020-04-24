package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.impl

import java.util.Collection
import org.osgi.service.component.annotations.Component
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.PcmQueryUtils
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.repository.OperationSignature
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult
import java.util.Map
import org.eclipse.core.runtime.IProgressMonitor
import org.palladiosimulator.pcm.repository.Repository
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.SeffWithContext
import org.palladiosimulator.pcm.repository.OperationProvidedRole

@Component
class DataTypeUsageStorageConsideringQueryImpl extends DataTypeUsageQueryImpl implements DataTypeUsageAnalysis {
	
	val extension PcmQueryUtils pcmQueryUtils = new PcmQueryUtils
	val extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils

	override getName() {
		"Usage Query (Further Searching from Store)"
	}
	
	override getUUID() {
		"489124cf-3565-4340-a944-6f7349602080"
	}
	
	override Map<EntryLevelSystemCall, DataTypeUsageAnalysisResult> getUsedDataTypes(
            Iterable<EntryLevelSystemCall> elscs, IProgressMonitor monitor) throws InterruptedException {
            	
		val result = super.getUsedDataTypes(elscs, monitor)
		
		// find elscs to db relevant operations
		// determine addition data types for getters of db
		 
		result
    }

	protected override void handleDBSignatureCall(OperationSignature calledSignature, EntryLevelSystemCall elsc,
		SeffWithContext seff, ExternalCallAction eca, Collection<DataType> readData, Collection<DataType> writeData) {
		super.handleDBSignatureCall(calledSignature, elsc, seff, eca, readData, writeData)
		
		
		
//		if (!calledSignature.parameters__OperationSignature.isEmpty) {
//			// setter called, nothing to do here
//		}
//		
//		// find db setter
//		val setterSignature = calledSignature.interface__OperationSignature.signatures__OperationInterface.filter[s | s.getParameters__OperationSignature().empty].head
//		
//		// assumption: all calls to
//		val repository = findParentOfType(calledSignature, Repository)
//		
//		val calledSeff = eca.role_ExternalService.findCalledSeff(calledSignature, seff.context)
//		calledSignature.get
//		
//		val dbAssemblyContext = calledSeff.context.last
//		dbAssemblyContext.encapsulatedComponent__AssemblyContext.providedRoles_InterfaceProvidingEntity.filter(OperationProvidedRole).filter[r | r.providedInterface__OperationProvidedRole == ]
//		
//		repository.findChildrenOfType(ExternalCallAction).
		
	}

}