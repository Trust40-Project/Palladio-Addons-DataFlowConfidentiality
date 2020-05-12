package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import java.util.ArrayList
import java.util.Collection
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.DataTypeUsageQueryResultImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransitiveTransformationTrace
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.prolog4j.Query

class ActualDataTypesAtELSCsAnalysisRun extends AnalysisRunBase {

	new(Iterable<EntryLevelSystemCall> elscs) {
		super(elscs)
	}

	override protected performAnalysisForNode(String nodeId, TransitiveTransformationTrace trace) {
		val readDataTypeResult = nodeId.buildAnalysisQueryForReadData(trace).executeQueryForDataTypes
		val writeDataTypeResult = nodeId.buildAnalysisQueryForWrittenData(trace).executeQueryForDataTypes
		buildDataTypeUsageQueryResult(readDataTypeResult, writeDataTypeResult, trace)
	}

	protected def buildAnalysisQueryForWrittenData(String nodeId, TransitiveTransformationTrace trace) {
		// hacky solution
		if (nodeId.toLowerCase.contains("entry")) {
			return nodeId.buildAnalysisQueryForWrittenDataReal(trace)
		} else {
			return nodeId.buildAnalysisQueryForDataDummy(trace)
		}
	}

	protected def buildAnalysisQueryForWrittenDataReal(String nodeId, TransitiveTransformationTrace trace) {
		val query = prover.query('''
			CTNODE = ?CTNODE,
			VNODE = ?VNODE,
			CTDTS = ?CTDTS,
			store(P),
			inputPin(P, PIN),
			characteristic(P, PIN, CTNODE, VNODE, S),
			setof(X, characteristic(P, PIN, CTDTS, X, S), DTS).
		''')
		query.bind("J$CTNODE", trace.traversedNodesCharacteristicTypeId)
		query.bind("J$VNODE", nodeId)
		query.bind("J$CTDTS", trace.actualDataTypesCharacteristicTypeId)
		query
	}

	protected def buildAnalysisQueryForReadData(String nodeId, TransitiveTransformationTrace trace) {
		// hacky solution
		if (nodeId.toLowerCase.contains("entry")) {
			return nodeId.buildAnalysisQueryForDataDummy(trace)
		} else {
			return nodeId.buildAnalysisQueryForReadDataReal(trace)
		}
	}

	protected def buildAnalysisQueryForDataDummy(String nodeId, TransitiveTransformationTrace trace) {
		prover.query("TMP = [], DTS = TMP, S = TMP.")
	}

	protected def buildAnalysisQueryForReadDataReal(String nodeId, TransitiveTransformationTrace trace) {
		val query = prover.query('''
			CTDTS = ?CTDTS,
			VNODE = ?VNODE,
			nodeLiteral(VNODE, P),
			(
				inputPin(P, PIN);
				outputPin(P, PIN)
			),
			setof(X, characteristic(P, PIN, CTDTS, X, S), DTS).
		''')
		query.bind("J$CTDTS", trace.actualDataTypesCharacteristicTypeId)
		query.bind("J$VNODE", nodeId)
		query
	}

	protected def executeQueryForDataTypes(Query query) {
		val queryResults = query.executeQuery(#{"DTS" -> Collection, "S" -> Collection})
		val results = new ArrayList()
		for (queryResult : queryResults) {
			val dataTypeIds = queryResult.get("DTS") as Collection<String>
			val traceids = queryResult.get("S") as Collection<Collection<String>>
			val dataTypeAndTrace = new DataTypeAndTrace(dataTypeIds, traceids)
			results += dataTypeAndTrace
		}
		results
	}
	
	protected def buildDataTypeUsageQueryResult(Collection<DataTypeAndTrace> readDataTypeResult, Collection<DataTypeAndTrace> writeDataTypeResult, TransitiveTransformationTrace trace) {
		val Collection<DataTypeUsageAnalysisResult> result = new ArrayList
		val readByFlows = readDataTypeResult.groupBy[dataFlowIds]
		val writeByFlows = writeDataTypeResult.groupBy[dataFlowIds]
		val keys = (readByFlows.keySet + writeByFlows.keySet).toSet
		for (key : keys) {
			val readDataTypes = readByFlows.getOrDefault(key, #[]).flatMap[dataTypeIds].map[getDataType(trace)].toSet
			val writeDataTypes = writeByFlows.getOrDefault(key, #[]).flatMap[dataTypeIds].map[getDataType(trace)].toSet
			val dataFlowGraph = key.flatten.getDataFlowGraph(trace)
			result += new DataTypeUsageQueryResultImpl(readDataTypes, writeDataTypes, dataFlowGraph)
		}
		result
	}

}
