package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.test

import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.impl.DataTypeUsageQueryImpl
import org.palladiosimulator.pcm.core.entity.Entity
import org.palladiosimulator.pcm.repository.CollectionDataType
import org.palladiosimulator.pcm.repository.CompositeDataType
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.repository.PrimitiveDataType
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.test.StandaloneUtils.getModelURI
import org.eclipse.core.runtime.NullProgressMonitor

class DataTypeUsageQueryTest {
	
	DataTypeUsageAnalysis subject
	
	@BeforeAll
	static def void init() {
		StandaloneUtils.init
	}
	
	@BeforeEach
	def void setup() {
		subject = new DataTypeUsageQueryImpl
	}
	
	@Test
	def void testTravelPlanner() throws InterruptedException {
		val rs = new ResourceSetImpl
		val usageModel = rs.getResource(getModelURI("TravelPlanner/newUsageModel.usagemodel"), true).contents.
			head as UsageModel
		val elscs = usageModel.eAllContents.filter(EntryLevelSystemCall)

		val queryFlightsElsc = elscs.findFirst[entityName == "queryFlights"]
		val queryResults = subject.getUsedDataTypes(queryFlightsElsc, new NullProgressMonitor)
		assertEquals(1, queryResults.size)
		val actualQueryFlights = queryResults.last
		
		assertTrue(actualQueryFlights.writeDataTypes.empty)
		assertEquals(3, actualQueryFlights.readDataTypes.size)
		assertEquals(1, actualQueryFlights.readDataTypes.filter(PrimitiveDataType).size)
		assertFalse(actualQueryFlights.readDataTypes.filter(Entity).filter[entityName == "Flights"].isEmpty)
		assertFalse(actualQueryFlights.readDataTypes.filter(Entity).filter[entityName == "Flight"].isEmpty)
		
		//TODO do more
	}
	
	@Test
	def void testLoyaltyCardOnlinePurchase() {
		val elsc = "LoyaltyCard/MakeStorePurchaseOnline.bpusagemodel".findElsc("submit online order")
		val queryResults = subject.getUsedDataTypes(elsc, new NullProgressMonitor)
		assertEquals(1, queryResults.size)
		val actual = queryResults.last
		assertEquals(#{"Order"}, actual.writeDataTypes)
		assertEquals(#{"Order", "OnlineOrder", "Customer", "INT"}, actual.readDataTypes)
	}
	
	@Test
	def void testLoyaltyCardPurchaseWithLoyaltyProgram() {
		val elsc = "LoyaltyCard/MakeStorePurchaseWithLoyaltyProgram.bpusagemodel".findElsc("submit order")
		val queryResults = subject.getUsedDataTypes(elsc, new NullProgressMonitor)
		assertEquals(1, queryResults.size)
		val actual = queryResults.last
		assertEquals(#{"Order"}, actual.writeDataTypes)
		assertEquals(#{"Order", "INT", "Customer", "LoyaltyCustomer", "LoyaltyOrder"}, actual.readDataTypes)
	}
	
	protected def EntryLevelSystemCall findElsc(String modelName, String requiredName) {
		val rs = new ResourceSetImpl
		val usageModel = rs.getResource(getModelURI(modelName), true).contents.
			head as UsageModel
		val elsc = usageModel.eAllContents.filter(EntryLevelSystemCall).findFirst[entityName == requiredName]
		elsc
	}
	
	protected def assertEquals(Iterable<String> expectedNames, Iterable<DataType> dataTypes) {
		val actualNameSet = dataTypes.map[name].toSet
		val expectedNameSet = expectedNames.toSet
		assertEquals(expectedNameSet, actualNameSet)
	}
	
	protected def print(DataTypeUsageAnalysisResult result, EntryLevelSystemCall elsc) {
		println(result.serialize(elsc))
	}
	
	protected def serialize(DataTypeUsageAnalysisResult result, EntryLevelSystemCall elsc) '''
	ELSC: «elsc.entityName» («elsc.id»)
		Read:
			«result.readDataTypes.serialize»
		Write:
			«result.writeDataTypes.serialize»
	'''

	protected def serialize(Iterable<DataType> dts) '''
		«FOR dt : dts»
			«dt.name»
		«ENDFOR»
	'''
	
	protected def dispatch getName(PrimitiveDataType dt) {
		dt.type.literal
	}
	
	protected def dispatch getName(CollectionDataType dt) {
		dt.entityName
	}
	
	protected def dispatch getName(CompositeDataType dt) {
		dt.entityName
	}
}