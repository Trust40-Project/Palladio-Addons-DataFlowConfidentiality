package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased.impl

import java.util.Collection
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.dto.DataTypeUsageQueryResultImpl
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransitiveTransformationTrace
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.prolog4j.Query

class ActualDataTypesAtELSCsAnalysisRun extends AnalysisRunBase {
	
	new(Iterable<EntryLevelSystemCall> elscs) {
		super(elscs)
	}
	
	override protected performAnalysisForNode(String nodeId, TransitiveTransformationTrace trace) {
		val readDataTypeIds = nodeId.buildAnalysisQueryForReadData(trace).executeQueryForDataTypes
		val readDataTypes = readDataTypeIds.getDataTypes(trace).toList
		val writeDataTypeIds = nodeId.buildAnalysisQueryForWrittenData(trace).executeQueryForDataTypes
		val writeDataTypes = writeDataTypeIds.getDataTypes(trace).toList
		new DataTypeUsageQueryResultImpl(readDataTypes, writeDataTypes)
	}
	
	protected def executeQueryForDataTypes(Query query) {
		val result = query.executeQuery(#{ "DTS" -> Collection})
		result.map[get("DTS")].filterNull.flatMap[v | v as Collection<String>].toSet
	}
	
	protected def buildAnalysisQueryForWrittenData(String nodeId, TransitiveTransformationTrace trace) {
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
	
}