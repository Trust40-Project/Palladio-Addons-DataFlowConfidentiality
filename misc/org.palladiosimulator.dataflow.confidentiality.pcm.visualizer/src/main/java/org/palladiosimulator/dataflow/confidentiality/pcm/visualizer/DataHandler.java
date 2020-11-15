package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.function.Function;
import java.util.stream.Collectors;

import javax.swing.event.ListSelectionEvent;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.TableModel;

import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataFlowGraph;
import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataFlowResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataFlowResultParser;
import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataTypeUsage;
import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.Entity;

public class DataHandler {

	private final ExecutorService executorService = Executors.newSingleThreadExecutor();
	private final DefaultTableModel elscTableModel;
	private final DefaultTableModel readTableModel;
	private final DefaultTableModel writeTableModel;
	private final DefaultTableModel graphTableModel;
	private List<DataTypeUsage> dataTypeUsages;
	private Entity selectedElsc;

	public DataHandler() {
		elscTableModel = createTableModel("id", "name");
		readTableModel = createTableModel("id", "name");
		writeTableModel = createTableModel("id", "name");
		graphTableModel = createTableModel("id");
	}

	public void initFromJsonFile(File file) throws IOException {
		DataFlowResultParser parser = new DataFlowResultParser();
		DataFlowResult result = parser.parse(file);

		executorService.submit(() -> {
			dataTypeUsages = result.getDataTypeUsage();
			Set<Entity> elscs = dataTypeUsages.stream().map(DataTypeUsage::getEntryLevelSystemCall)
					.collect(Collectors.toSet());
			replaceEntityTable(elscTableModel, elscs);
		});
	}

	public void elscSelectionChanged(String id, String name) {
		executorService.submit(() -> {
			selectedElsc = new Entity(id, name);
			List<DataTypeUsage> relevantUsages = dataTypeUsages.stream()
					.filter(u -> u.getEntryLevelSystemCall().equals(selectedElsc)).distinct().collect(Collectors.toList());
			Set<Entity> readDataTypes = relevantUsages.stream().map(DataTypeUsage::getReadDataTypes)
					.flatMap(Collection::stream).collect(Collectors.toSet());
			Set<Entity> writeDataTypes = relevantUsages.stream().map(DataTypeUsage::getWriteDataTypes)
					.flatMap(Collection::stream).collect(Collectors.toSet());

			replaceEntityTable(readTableModel, readDataTypes);
			replaceEntityTable(writeTableModel, writeDataTypes);
			clean(graphTableModel);
		});
	}

	public void readSelectionChanged(String id, String name) {
		executorService.submit(() -> {
			dataTypeSelectionChanged(readTableModel, new Entity(id, name), DataTypeUsage::getReadDataTypes);
		});
	}

	public void writeSelectionChanged(String id, String name) {
		executorService.submit(() -> {
			dataTypeSelectionChanged(writeTableModel, new Entity(id, name), DataTypeUsage::getWriteDataTypes);
		});
	}

	protected void dataTypeSelectionChanged(DefaultTableModel model, Entity entity,
			Function<DataTypeUsage, List<Entity>> dataTypesGetter) {
		Collection<DataFlowGraph> graphs = dataTypeUsages.stream()
				.filter(u -> u.getEntryLevelSystemCall().equals(selectedElsc))
				.filter(u -> dataTypesGetter.apply(u).contains(entity))
				.filter(u -> u.getDataFlowGraph().isPresent())
				.map(DataTypeUsage::getDataFlowGraph)
				.filter(Optional::isPresent)
				.map(Optional::get)
				.collect(Collectors.toSet());

		clean(graphTableModel);
		graphs.forEach(graph -> graphTableModel.addRow(new Object[] { graph }));
	}

	public TableModel getElscModel() {
		return elscTableModel;
	}

	public TableModel getReadDataTypesModel() {
		return readTableModel;
	}

	public TableModel getWriteDataTypesModel() {
		return writeTableModel;
	}

	public TableModel getDataFlowGraphsModel() {
		return graphTableModel;
	}

	protected static DefaultTableModel createTableModel(String... columnNames) {
		DefaultTableModel model = new DefaultTableModel();
		for (String columnName : columnNames) {
			model.addColumn(columnName);
		}
		return model;
	}

	protected static Optional<Entity> createEntity(DefaultTableModel model, ListSelectionEvent event) {
		if (event.getLastIndex() < 0 || event.getLastIndex() >= model.getRowCount()) {
			return Optional.empty();
		}

		Entity selectedElsc = new Entity();
		selectedElsc.setId((String) model.getValueAt(event.getLastIndex(), 0));
		selectedElsc.setName((String) model.getValueAt(event.getLastIndex(), 1));
		return Optional.of(selectedElsc);
	}

	protected static void replaceEntityTable(DefaultTableModel model, Set<Entity> entries) {
		clean(model);
		for (Entity entity : entries) {
			model.addRow(new Object[] { entity.getId(), entity.getName() });
		}
	}
	
	protected static void clean(DefaultTableModel model) {
		while (model.getRowCount() > 0) {
			model.removeRow(0);
		}
		model.fireTableDataChanged();
	}

}
