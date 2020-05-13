package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import de.uka.ipd.sdq.identifier.Identifier
import de.uka.ipd.sdq.workflow.WorkflowExceptionHandler
import java.io.File
import java.nio.file.Files
import java.util.ArrayList
import java.util.Collection
import java.util.HashMap
import java.util.LinkedHashSet
import java.util.Map
import java.util.Optional
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.SubMonitor
import org.palladiosimulator.dataflow.confidentiality.defaultmodels.DefaultModelConstants
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstance
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult.EntityInstanceRelation
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.Activator
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.DataFlowGraphImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.EntityInstanceImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.EntityInstanceRelationImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMRelatedTraceElement
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMSingleTraceElement
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflow
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransformPCMDFDToPrologWorkflowFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransitiveTransformationTrace
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.jobs.TransformPCMDFDToPrologJobBuilder
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.UsageModel
import org.prolog4j.Prover
import org.prolog4j.Query
import org.prolog4j.Solution

abstract class AnalysisRunBase {

	protected extension ModelQueryUtils modelQueryUtils = new ModelQueryUtils
	protected val Prover prover
	val Iterable<EntryLevelSystemCall> elscs
	var executed = false

	new(Iterable<EntryLevelSystemCall> elscs) {
		this.prover = getProver.orElseThrow
		this.elscs = elscs
	}

	def run(IProgressMonitor monitor) throws InterruptedException {
		if (executed) {
			throw new IllegalStateException("The object is not reusable.")
		}
		executed = true

		val subMonitor = SubMonitor.convert(monitor, "Analyze Data Type Usage", 3);
		val transformationJob = createTransformationJob(subMonitor, new WorkflowExceptionHandler(true))
		transformationJob.run
		subMonitor.worked(1)
		transformationJob.initializeProver
		val trace = transformationJob.trace.orElseThrow
		subMonitor.worked(1)
		val result = trace.performAnalysisForCalls(subMonitor)
		subMonitor.worked(1)
		subMonitor.done()
		result
	}

	protected def performAnalysisForCalls(TransitiveTransformationTrace trace, IProgressMonitor monitor) throws InterruptedException {
		val subMonitor = SubMonitor.convert(monitor, "ELSC Analysis", elscs.size)
		val result = new HashMap<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>>
		for (elsc : elscs) {
			val dataTypeUsage = elsc.performAnalysisForCall(trace)
			result.put(elsc, dataTypeUsage)
			subMonitor.worked(1)
			if (subMonitor.canceled) {
				throw new InterruptedException
			}
		}
		subMonitor.done()
		result
	}

	protected def performAnalysisForCall(EntryLevelSystemCall elsc, TransitiveTransformationTrace trace) {
		val dataTypeUsageResults = new ArrayList<DataTypeUsageAnalysisResult>()
		val factIds = trace.getLiteralFactIds(elsc)
		for (factId : factIds) {
			dataTypeUsageResults += factId.performAnalysisForNode(trace)
		}
//		val readDataTypes = dataTypeUsageResults.flatMap[readDataTypes].toSet
//		val writeDataTypes = dataTypeUsageResults.flatMap[writeDataTypes].toSet
//		
//		new DataTypeUsageQueryResultImpl(readDataTypes, writeDataTypes)
		dataTypeUsageResults
	}

	protected abstract def Collection<DataTypeUsageAnalysisResult> performAnalysisForNode(String nodeId, TransitiveTransformationTrace trace);

	protected def isStore(String nodeId) {
		val isStoreQuery = prover.query('''store(?P).''')
		isStoreQuery.bind("J$P", nodeId);
		isStoreQuery.solve().isSuccess
	}

	protected def initializeProver(TransformPCMDFDToPrologWorkflow job) {
		val prologProgram = job.prologProgram.orElseThrow
		Files.writeString(new File("D:\\tmp\\loyalty.pl").toPath, prologProgram) //FIXME remove
		prover.addTheory(prologProgram)
	}

	protected def createTransformationJob(IProgressMonitor monitor, WorkflowExceptionHandler exceptionHandler) {
		val usageModels = elscs.map[findParentOfType(UsageModel)].filterNull
		val transformationJob = TransformPCMDFDToPrologJobBuilder.create.addSerializeModelToString.
			addUsageModels(usageModels).build
		val workflow = TransformPCMDFDToPrologWorkflowFactory.createWorkflow(transformationJob, monitor,
			exceptionHandler)
		workflow
	}

	protected static def getProver() {
		proverFactory.map[createProver]
	}

	protected static def getProverFactory() {
		val provers = Activator.instance.proverManager.getProvers()
		val preferredProver = provers.filter[proverInfo, prover|!proverInfo.needsNativeExecutables].values.head
		var prover = Optional.ofNullable(preferredProver)
		if (prover.isEmpty) {
			prover = Optional.ofNullable(provers.values.head)
		}
		prover
	}
	
	protected def getTraversedNodesCharacteristicTypeId(TransitiveTransformationTrace trace) {
		trace.getFactId([ ct |
			ct.id == DefaultModelConstants.CT_TRAVERSED_NODES_ID
		]).head
	}
	
	protected def getActualDataTypesCharacteristicTypeId(TransitiveTransformationTrace trace) {
		trace.getFactId([ ct |
			ct.id == org.palladiosimulator.dataflow.confidentiality.pcm.resources.DefaultModelConstants.
				CT_ACTUAL_DATATYPE_ID
		]).head
	}
	
	protected def executeQuery(Query query, Map<String, Class<?>> expectedVariables) {
		val solution = query.solve()
		if (!solution.success) {
			return #[]
		}
		solution.getSolutions(expectedVariables)
	}
	
	protected def getSolutions(Solution<Object> solution, Map<String, Class<?>> expectedVariables) {
		val solutions = new ArrayList<Map<String, Object>>()
		for (var solutionIter = solution.iterator; solutionIter.hasNext; solutionIter.next) {
			val solutionEntry = new HashMap<String, Object>();
			for (variable : expectedVariables.keySet) {
				val value = solutionIter.get(variable)
				val valueType = expectedVariables.get(variable)
				if (!valueType.isInstance(value)) {
					throw new IllegalArgumentException('''Wrong type «valueType.simpleName» for variable «variable».''')
				}
				solutionEntry.put(variable, value)
			}
			solutions.add(solutionEntry)
		}
		solutions
	}

	protected def getDataType(String id, TransitiveTransformationTrace trace) {
		trace.getPCMEntries(id).filter(PCMSingleTraceElement).map[element].filter(DataType).head
	}
	
	protected def getDataFlowGraph(Iterable<String> dataFlowIds, TransitiveTransformationTrace trace) {
		val Collection<EntityInstance> nodes = new LinkedHashSet
		val Collection<EntityInstanceRelation> edges = new LinkedHashSet
		
		for (dataFlowId : dataFlowIds) {
			val pcmRelation = trace.getPCMEntries(dataFlowId).filter(PCMRelatedTraceElement).head
			
			val EntityInstance fromEntity = new EntityInstanceImpl(pcmRelation.fromElement.element as Identifier, pcmRelation.fromElement.context).getCached(nodes)
			val EntityInstance toEntity = new EntityInstanceImpl(pcmRelation.toElement.element as Identifier, pcmRelation.toElement.context).getCached(nodes)
			nodes += fromEntity
			nodes += toEntity
			if (fromEntity != toEntity) {
				edges += new EntityInstanceRelationImpl(fromEntity, toEntity)
			}
		}
		
		new DataFlowGraphImpl(nodes, edges)
	}
	
	protected static def <T> T getCached(T element, Collection<T> cache) {
		if (cache.contains(element)) {
			return cache.findFirst[cacheElement | cacheElement.equals(element)]
		}
		return element
	}
	
}
