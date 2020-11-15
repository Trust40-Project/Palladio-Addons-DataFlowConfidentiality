package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer;

import java.awt.BorderLayout;
import java.awt.Canvas;
import java.awt.Component;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.function.BiConsumer;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.ListSelectionModel;
import javax.swing.UIManager;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.table.TableModel;
import javax.swing.table.TableRowSorter;

import org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io.DataFlowGraph;

public class MainFrame extends JFrame {

	private static final long serialVersionUID = 4643651355460736442L;
	private JPanel contentPane;
	private JTable elscsTable;
	private JTable writeTable;
	private JTable readTable;
	private JTable graphTable;
	private JScrollPane elscScrollPane;
	private JScrollPane readScrollPane;
	private JScrollPane writeScrollPane;
	private JScrollPane graphScrollPane;
	private DataHandler dataHandler;
	private Canvas canvasDfGraph;

	/**
	 * Create the frame.
	 */
	public MainFrame() {
		dataHandler = new DataHandler();

		setTitle("Data Type Usage Visualizer");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 300);

		JMenuBar menuBar = new JMenuBar();
		setJMenuBar(menuBar);

		JMenu mnFile = new JMenu("File");
		menuBar.add(mnFile);

		JMenuItem mntmOpen = new JMenuItem("Open...");
		mntmOpen.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Optional<File> selectedFile = showOpenDialog(MainFrame.this);
				if (selectedFile.isPresent()) {
					try {
						dataHandler.initFromJsonFile(selectedFile.get());
					} catch (IOException ex) {
						JOptionPane.showMessageDialog(MainFrame.this, "The file could not be load: " + ex.getMessage(),
								"Error", JOptionPane.ERROR_MESSAGE);
					}
				}
			}
		});
		mnFile.add(mntmOpen);

		JMenuItem mntmClose = new JMenuItem("Close");
		mntmClose.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				System.exit(0);
			}
		});
		mnFile.add(mntmClose);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(new GridLayout(1, 3, 4, 1));

		JPanel panelElsc = new JPanel();
		contentPane.add(panelElsc);
		panelElsc.setLayout(new BorderLayout(0, 0));

		JLabel lblElscs = new JLabel("ELSCs");
		panelElsc.add(lblElscs, BorderLayout.NORTH);

		elscsTable = new JTable();
		elscsTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		elscsTable.setModel(dataHandler.getElscModel());
		TableRowSorter<TableModel> sorter = new TableRowSorter<TableModel>(elscsTable.getModel());
		elscsTable.setRowSorter(sorter);
		elscsTable.getSelectionModel()
				.addListSelectionListener(event -> inform(elscsTable, dataHandler::elscSelectionChanged));
		elscScrollPane = new JScrollPane();
		elscScrollPane.setViewportView(elscsTable);
		panelElsc.add(elscScrollPane, BorderLayout.CENTER);

		JPanel panelDataTypes = new JPanel();
		contentPane.add(panelDataTypes);
		panelDataTypes.setLayout(new GridLayout(0, 1, 0, 0));

		JPanel panelReadDataTypes = new JPanel();
		panelDataTypes.add(panelReadDataTypes);
		panelReadDataTypes.setLayout(new BorderLayout(0, 0));

		JLabel lblReadDts = new JLabel("Read DTs");
		panelReadDataTypes.add(lblReadDts, BorderLayout.NORTH);

		readTable = new JTable();
		readTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		readTable.setModel(dataHandler.getReadDataTypesModel());
		readTable.getSelectionModel()
				.addListSelectionListener(event -> inform(readTable, dataHandler::readSelectionChanged));
		readScrollPane = new JScrollPane();
		readScrollPane.setViewportView(readTable);
		panelReadDataTypes.add(readScrollPane, BorderLayout.CENTER);

		JPanel panelWriteDataTypes = new JPanel();
		panelDataTypes.add(panelWriteDataTypes);
		panelWriteDataTypes.setLayout(new BorderLayout(0, 0));

		JLabel lblWriteDts = new JLabel("Write DTs");
		panelWriteDataTypes.add(lblWriteDts, BorderLayout.NORTH);

		writeTable = new JTable();
		writeTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		writeTable.setModel(dataHandler.getWriteDataTypesModel());
		writeTable.getSelectionModel()
				.addListSelectionListener(event -> inform(writeTable, dataHandler::writeSelectionChanged));
		writeScrollPane = new JScrollPane();
		writeScrollPane.setViewportView(writeTable);
		panelWriteDataTypes.add(writeScrollPane, BorderLayout.CENTER);

		JPanel panelGraphs = new JPanel();
		contentPane.add(panelGraphs);
		panelGraphs.setLayout(new GridLayout(2, 1, 0, 0));

		JPanel panelDfGraphSelection = new JPanel();
		panelGraphs.add(panelDfGraphSelection);
		panelDfGraphSelection.setLayout(new BorderLayout(0, 0));

		JLabel lblDfGraphs = new JLabel("DF Graphs");
		panelDfGraphSelection.add(lblDfGraphs, BorderLayout.NORTH);
		
		final JPanel panelDfGraph = new JPanel();
		panelGraphs.add(panelDfGraph);
		panelDfGraph.setLayout(new BorderLayout(0, 0));
		
		JLabel lblNewLabel = new JLabel("DF Graph");
		panelDfGraph.add(lblNewLabel, BorderLayout.NORTH);
		
		JPanel panelDfGraphCanvas = new JPanel();
		panelDfGraphCanvas.setBorder(new LineBorder(UIManager.getColor("Table.gridColor")));
		panelDfGraph.add(panelDfGraphCanvas, BorderLayout.CENTER);
		panelDfGraphCanvas.setLayout(new BorderLayout(0, 0));
		
		canvasDfGraph = new Canvas();
		panelDfGraphCanvas.add(canvasDfGraph, BorderLayout.CENTER);
		canvasDfGraph.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				if (e.getComponent() != canvasDfGraph) {
					return;
				}
				DataFlowGraphDialog dialog = new DataFlowGraphDialog(MainFrame.this, true);
				dialog.setImageProvider((width, height) -> {
					Optional<DataFlowGraphRenderer> renderer = getDataFlowGraphRenderer();
					if (renderer.isPresent()) {
						return renderer.get().getImage(width, height);
					}
					return new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
				});
				dialog.setVisible(true);
			}
		});

		graphTable = new JTable();
		graphTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		graphTable.setModel(dataHandler.getDataFlowGraphsModel());
		graphTable.getSelectionModel().addListSelectionListener(event -> {
			Optional<DataFlowGraphRenderer> renderer = getDataFlowGraphRenderer();
			if (renderer.isPresent()) {
				BufferedImage image = renderer.get().getImage(canvasDfGraph.getWidth(), canvasDfGraph.getHeight());
				canvasDfGraph.getGraphics().drawImage(image, 0, 0, null);
			}
		});
		graphScrollPane = new JScrollPane();
		panelDfGraphSelection.add(graphScrollPane);
		graphScrollPane.setViewportView(graphTable);

	}

	protected Optional<DataFlowGraphRenderer> getDataFlowGraphRenderer() {
		int selectedRow = graphTable.getSelectedRow();
		if (selectedRow < 0) {
			return Optional.empty();
		}
		DataFlowGraph graph = (DataFlowGraph) graphTable.getValueAt(selectedRow, 0);
		DataFlowGraphRenderer renderer = new DataFlowGraphRenderer(graph);
		return Optional.of(renderer);
	}

	protected void inform(JTable table, BiConsumer<String, String> entityHandler) {
		if (table.getSelectedRow() < 0) {
			return;
		}
		String id = (String) table.getValueAt(table.getSelectedRow(), 0);
		String name = (String) table.getValueAt(table.getSelectedRow(), 1);
		entityHandler.accept(id, name);
		canvasDfGraph.getGraphics().clearRect(0, 0, canvasDfGraph.getWidth(), canvasDfGraph.getHeight());
	}

	protected static Optional<File> showOpenDialog(Component parent) {
		JFileChooser fileChooser = new JFileChooser(Paths.get(".").toFile());
		fileChooser.setFileFilter(new FileNameExtensionFilter("*.json", "json"));
		fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
		fileChooser.setMultiSelectionEnabled(false);
		if (fileChooser.showOpenDialog(parent) == JFileChooser.APPROVE_OPTION) {
			return Optional.of(fileChooser.getSelectedFile());
		}
		return Optional.empty();
	}

}
