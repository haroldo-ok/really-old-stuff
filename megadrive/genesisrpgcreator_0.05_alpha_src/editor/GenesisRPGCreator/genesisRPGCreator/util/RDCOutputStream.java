/*
 * Created on 25/04/2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package genesisRPGCreator.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FilterOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * @author Haroldo O. Pinheiro
 *
 * This class is a Java port of a Pascal port of a C library.
 * Below is the original copyright notice:
 *
 (***************************************************
 * RDC Unit                                        *
 *                                                 *
 * This is a Pascal port of C code from an article *
 * In "The C Users Journal", 1/92 Written by       *
 * Ed Ross.                                        *
 *                                                 *
 * This particular code has worked well under,     *
 * Real, Protected and Windows.                    *
 *                                                 *
 * The compression is not quite as good as PKZIP   *
 * but it decompresses about 5 times faster.       *
 ***************************************************)
 *
 */

public class RDCOutputStream extends FilterOutputStream {
	protected static int HASH_LEN = 4096;  // # hash table entries
	protected static int BUFF_LEN = 16384; // size of compression buffer
	
	protected ByteArrayOutputStream inbuffer = new ByteArrayOutputStream();	

	/**
	 * @param out
	 */
	public RDCOutputStream(OutputStream out) {	
		super(out);
	}

	/* (non-Javadoc)
	 * @see java.io.OutputStream#close()
	 */
	public void close() throws IOException {
		flush();
		// Add trailer to indicate end of file
		Util.writeShort(0, out);	
		out.close();
	}

	/* (non-Javadoc)
	 * @see java.io.OutputStream#flush()
	 */
	public void flush() throws IOException {
		ByteArrayInputStream in = new ByteArrayInputStream(inbuffer.toByteArray());
		compressStream(in, out);
		inbuffer.reset();
		
		super.flush();
	}
	
	/* (non-Javadoc)
	 * @see java.io.OutputStream#write(int)
	 */
	public void write(int b) throws IOException {
		inbuffer.write(b);
/*		if(inbuffer.size() >= BUFF_LEN) {
			flush();
		}*/
	}
	
	protected void compressStream(InputStream in, OutputStream out) throws IOException {
		byte[] inbuf        = new byte[BUFF_LEN];
		byte[] outbuf       = new byte[BUFF_LEN];
		int[]  hashtable    = new int[HASH_LEN];
		int    code         = 0;
		int    bytes_read   = 0;
		int    compress_len = 0;
		
		/* read infile BUFF_LEN bytes at a time */
		
		bytes_read = BUFF_LEN;
		while(bytes_read == BUFF_LEN) {
			bytes_read = in.read(inbuf, 0, BUFF_LEN);

		    /* compress this load of bytes */
			compress_len = rdcCompress(inbuf, bytes_read, outbuf, hashtable);

		    /* write length of compressed buffer */
			Util.writeShort(compress_len, out);

		    /* check for negative length indicating the buffer could not be compressed */
		    if(compress_len < 0) {
		      compress_len = -compress_len;
		    }

		    /* write the buffer */
		    out.write(outbuf, 0, compress_len);
		    /* we're done if less than full buffer was read */
		}		
	}
	
	protected int rdcCompress(byte[] inbuff, int inbuff_len, byte[] outbuff, int[] hash_tbl) throws IOException {
		int in_idx;
		int inbuff_end;
		int anchor = 0;
		int pat_idx;
		int cnt;
		int gap;
		int c = 0;
		int hash;
		int hashlen;
		int ctrl_idx;
		int ctrl_bits = 0;
		int ctrl_cnt;
		int out_idx;
		int outbuff_end;
		
		// Begin
		
		in_idx     = 0;
		inbuff_end = inbuff_len;
		ctrl_idx   = 0;
		ctrl_cnt   = 0;

		out_idx     = 2;
		outbuff_end = inbuff_len - 48;
		
		/* skip the compression for a small buffer */
		
		if(inbuff_len <= 18) {
			for(int i = 0; i != inbuff_len; i++) {
				outbuff[i] = inbuff[i];
			}
			return -inbuff_len;
		}
		
		/* adjust # hash entries so hash algorithm can
		 use 'and' instead of 'mod' */
		
		hashlen = HASH_LEN - 1;
		
		/* scan thru inbuff */
		
		while(in_idx < inbuff_end) {
			/* make room for the control bits
			 and check for outbuff overflow */
			
			if(ctrl_cnt == 16) {
				outbuff[ctrl_idx  ] = (byte)ctrl_bits;
				outbuff[ctrl_idx+1] = (byte)(ctrl_bits >> 8);
				ctrl_cnt = 1;
				ctrl_idx = out_idx;
				out_idx += 2;
				if(out_idx > outbuff_end) {					
					/*
					 Move(outbuff, inbuff, inbuff_len);
					 rdc_compress := inbuff_len;
					 Exit;
					 */
					// What was the routine above supposed to do?
					return inbuff_len;
				}
			} else {
				ctrl_cnt++;
			}
				
			/* look for rle */
			
			anchor = in_idx;
			c = inbuff[in_idx];
			in_idx++;
			
			while(  (in_idx < inbuff_end) &&
					(inbuff[in_idx] == c) &&
					( (in_idx - anchor) < (HASH_LEN + 18) ) ) {
				in_idx++;
			}
			
			/* store compression code if character is
			 repeated more than 2 times */
			
			cnt = in_idx - anchor;
			if(cnt > 2) {
				if(cnt <= 18) {     /* short rle */
					outbuff[out_idx] = (byte)(cnt - 3);
					out_idx++;
					outbuff[out_idx] = (byte)c;
					out_idx++;
				} else {            /* long rle */
					cnt -= 19;
					outbuff[out_idx] = (byte)(16 + (cnt & 0x0F));
					out_idx++;
					outbuff[out_idx] = (byte)(cnt >> 4);
					out_idx++;
					outbuff[out_idx] = (byte)c;
					out_idx++;
				}
				
				ctrl_bits = (ctrl_bits << 1) | 1;
				continue;
			}
			
			/* look for pattern if 2 or more characters
			 remain in the input buffer */
			
			in_idx = anchor;
			
			if(inbuff_end - in_idx > 2) {
				/* locate offset of possible pattern
				 in sliding dictionary */
				
				hash = ((((inbuff[in_idx+0] & 15) << 8) | inbuff[in_idx+1]) ^
						((inbuff[in_idx+0] >> 4) | (inbuff[in_idx+2] << 4)))
						& hashlen;
				
				pat_idx = in_idx;
				pat_idx = hash_tbl[hash];
				hash_tbl[hash] = in_idx;
				
				/* compare characters if we're within 4098 bytes */
				
				gap = in_idx - pat_idx;
				if (gap <= HASH_LEN + 2) {
					while ( (in_idx < inbuff_end)
							&& (pat_idx < anchor)
							&& (inbuff[pat_idx] == inbuff[in_idx])
							&& (in_idx - anchor < 271)) {
						in_idx++;
						pat_idx++;
					}						
					
					/* store pattern if it is more than 2 characters */
					
					cnt = in_idx - anchor;
					if(cnt > 2) {
						gap -= 3;
						
						if(cnt <= 15) {     /* short pattern */
							outbuff[out_idx] = (byte)((cnt << 4) + (gap & 0x0F));
							out_idx++;
							outbuff[out_idx] = (byte)(gap >> 4);
							out_idx++;
						} else {                   /* long pattern */
							outbuff[out_idx] = (byte)(32 + (gap & 0x0F));
							out_idx++;
							outbuff[out_idx] = (byte)(gap >> 4);
							out_idx++;
							outbuff[out_idx] = (byte)(cnt - 16);
							out_idx++;
						}
						
						ctrl_bits = (ctrl_bits << 1) | 1;
						continue;
					}
				}
			}
						
			
			/* can't compress this character
			 so copy it to outbuff */
			
			outbuff[out_idx] = (byte)c;
			out_idx++;
			anchor++;
			in_idx = anchor;
			ctrl_bits = ctrl_bits << 1;			
		}
		

		  /* save last load of control bits */

		  ctrl_bits = ctrl_bits << (16 - ctrl_cnt);
		  outbuff[ctrl_idx  ] = (byte)ctrl_bits;		  
		  outbuff[ctrl_idx+1] = (byte)(ctrl_bits >> 8);

		  /* and return size of compressed buffer */

		  return out_idx;
	}
}
