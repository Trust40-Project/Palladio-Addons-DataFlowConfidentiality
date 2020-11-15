package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer;

import java.awt.BorderLayout;
import java.awt.Canvas;
import java.awt.Frame;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.Collection;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import javax.swing.JDialog;

public class DataFlowGraphDialog extends JDialog {

	public interface ImageProvider {
		BufferedImage getImage(int width, int height);
	}

	private static final long serialVersionUID = -2633016852682149777L;
	private final Collection<ScheduledFuture<?>> scheduledTasks = new ArrayList<>();
	private final ScheduledExecutorService executorService = Executors.newSingleThreadScheduledExecutor();
	private ImageProvider imageProvider;

	/**
	 * Create the dialog.
	 */
	public DataFlowGraphDialog(Frame owner, boolean modal) {
		super(owner, modal);
		setTitle("Data  Flow Graph");
		setModalityType(ModalityType.APPLICATION_MODAL);
		setModal(true);
		setBounds(100, 100, 450, 300);

		final Canvas canvas = new Canvas();
		canvas.addComponentListener(new ComponentAdapter() {
			@Override
			public void componentResized(ComponentEvent e) {
				scheduleRedraw(canvas);
			}

			@Override
			public void componentShown(ComponentEvent e) {
				scheduleRedraw(canvas);
			}
		});
		getContentPane().add(canvas, BorderLayout.CENTER);

		setDefaultCloseOperation(DISPOSE_ON_CLOSE);
	}

	protected void scheduleRedraw(Canvas canvas) {
		synchronized (scheduledTasks) {
			scheduledTasks.forEach(future -> future.cancel(true));
			scheduledTasks.clear();
			scheduledTasks.add(executorService.schedule(() -> redrawImage(canvas), 500, TimeUnit.MILLISECONDS));
		}
	}

	protected void redrawImage(Canvas canvas) {
		BufferedImage image = imageProvider.getImage(canvas.getWidth(), canvas.getHeight());
		canvas.getGraphics().drawImage(image, 0, 0, null);
	}

	public void setImageProvider(ImageProvider imageProvider) {
		this.imageProvider = imageProvider;
	}

	@Override
	public void dispose() {
		executorService.shutdownNow();
		super.dispose();
	}

}
