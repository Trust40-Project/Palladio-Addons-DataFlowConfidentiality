package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.test

import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQuery
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQueryFactory
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQueryResult
import org.palladiosimulator.pcm.core.entity.Entity
import org.palladiosimulator.pcm.repository.CollectionDataType
import org.palladiosimulator.pcm.repository.CompositeDataType
import org.palladiosimulator.pcm.repository.DataType
import org.palladiosimulator.pcm.repository.PrimitiveDataType
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.usagemodel.UsageModel

import static org.junit.jupiter.api.Assertions.*
import static org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.test.StandaloneUtils.getModelURI

class DataTypeUsageQueryTest {
	
	DataTypeUsageQuery subject
	
	@BeforeAll
	static def void init() {
		StandaloneUtils.init
	}
	
	@BeforeEach
	def void setup() {
		subject = DataTypeUsageQueryFactory.create
	}
	
	@Test
	def void testTravelPlanner() {
		val rs = new ResourceSetImpl
		val usageModel = rs.getResource(getModelURI("TravelPlanner/newUsageModel.usagemodel"), true).contents.
			head as UsageModel
		val elscs = usageModel.eAllContents.filter(EntryLevelSystemCall)

		val queryFlightsElsc = elscs.findFirst[entityName == "queryFlights"]
		val actualQueryFlights = subject.getUsedDataTypes(queryFlightsElsc)
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
		val actual = subject.getUsedDataTypes(elsc)
		assertEquals(#{"Order"}, actual.writeDataTypes)
		assertEquals(#{"Order", "OnlineOrder", "Customer", "INT"}, actual.readDataTypes)
	}
	
	@Test
	def void testLoyaltyCardPurchaseWithLoyaltyProgram() {
		val elsc = "LoyaltyCard/MakeStorePurchaseWithLoyaltyProgram.bpusagemodel".findElsc("submit order")
		val actual = subject.getUsedDataTypes(elsc)
		assertEquals(#{"Order", "LoyaltyOrder"}, actual.writeDataTypes)
		assertEquals(#{"Order", "LoyaltyOrder", "Customer", "INT"}, actual.readDataTypes)
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
	
	protected def print(DataTypeUsageQueryResult result, EntryLevelSystemCall elsc) {
		println(result.serialize(elsc))
	}
	
	protected def serialize(DataTypeUsageQueryResult result, EntryLevelSystemCall elsc) '''
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